<?php

use App\Models\Transfer;
use App\Models\User;
use Laravel\Sanctum\Sanctum;

test('authenticated user can fetch recipients and transactions via api', function () {
    $sender = User::factory()->create();
    $recipient = User::factory()->create([
        'name' => 'Recipient User',
        'email' => 'recipient@example.com',
    ]);

    Sanctum::actingAs($sender);

    $this->getJson('/api/v1/recipients')
        ->assertOk()
        ->assertJsonCount(1, 'data')
        ->assertJsonPath('data.0.email', 'recipient@example.com');

    $this->getJson('/api/v1/transactions')
        ->assertOk()
        ->assertJsonPath('meta.total', 0);
});

test('authenticated user can transfer funds via api', function () {
    $sender = User::factory()->create();
    $recipient = User::factory()->create();

    $sender->wallet()->update(['balance' => 100000]);
    $recipient->wallet()->update(['balance' => 100000]);

    Sanctum::actingAs($sender);

    $this->postJson('/api/v1/transfers', [
        'recipient_user_id' => $recipient->id,
        'amount' => 25000,
    ])
        ->assertCreated()
        ->assertJsonPath('message', 'Transfer berhasil diproses.')
        ->assertJsonPath('wallet.balance', 75000)
        ->assertJsonPath('data.type', 'outgoing');

    expect($sender->wallet->fresh()->balance)->toBe(75000);
    expect($recipient->wallet->fresh()->balance)->toBe(125000);
    expect(Transfer::query()->count())->toBe(1);
});

test('guest cannot access protected api endpoints', function () {
    $this->getJson('/api/v1/dashboard')
        ->assertUnauthorized();
});
