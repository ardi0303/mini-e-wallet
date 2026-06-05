<?php

use App\Models\Transfer;
use App\Models\User;
use Inertia\Testing\AssertableInertia as Assert;

test('dashboard shows wallet balance and transfer recipients', function () {
    $sender = User::factory()->create();
    $recipient = User::factory()->create([
        'name' => 'Recipient User',
        'email' => 'recipient@example.com',
    ]);

    $sender->wallet()->update(['balance' => 125000]);

    $this->actingAs($sender)
        ->get(route('dashboard'))
        ->assertOk()
        ->assertInertia(fn (Assert $page) => $page
            ->component('dashboard/index')
            ->where('wallet.balance', 125000)
            ->has('transferForm.recipients', 1)
            ->where('transferForm.recipients.0.email', $recipient->email),
        );
});

test('authenticated user can transfer funds', function () {
    $sender = User::factory()->create();
    $recipient = User::factory()->create();

    $sender->wallet()->update(['balance' => 100000]);
    $recipient->wallet()->update(['balance' => 100000]);

    $response = $this->actingAs($sender)->post(route('transfers.store'), [
        'recipient_user_id' => $recipient->id,
        'amount' => 25000,
    ]);

    $response->assertRedirect(route('dashboard'));

    expect($sender->wallet->fresh()->balance)->toBe(75000);
    expect($recipient->wallet->fresh()->balance)->toBe(125000);
    expect(Transfer::query()->count())->toBe(1);
    expect(Transfer::query()->first()?->reference_id)->toStartWith('TRF-');
});

test('user cannot transfer to themselves', function () {
    $user = User::factory()->create();
    $user->wallet()->update(['balance' => 100000]);

    $response = $this
        ->actingAs($user)
        ->from(route('dashboard'))
        ->post(route('transfers.store'), [
            'recipient_user_id' => $user->id,
            'amount' => 1000,
        ]);

    $response
        ->assertRedirect(route('dashboard'))
        ->assertSessionHasErrors('recipient_user_id');

    expect(Transfer::query()->count())->toBe(0);
    expect($user->wallet->fresh()->balance)->toBe(100000);
});

test('user cannot transfer when balance is insufficient', function () {
    $sender = User::factory()->create();
    $recipient = User::factory()->create();

    $sender->wallet()->update(['balance' => 1000]);
    $recipient->wallet()->update(['balance' => 100000]);

    $response = $this
        ->actingAs($sender)
        ->from(route('dashboard'))
        ->post(route('transfers.store'), [
            'recipient_user_id' => $recipient->id,
            'amount' => 5000,
        ]);

    $response
        ->assertRedirect(route('dashboard'))
        ->assertSessionHasErrors('amount');

    expect(Transfer::query()->count())->toBe(0);
    expect($sender->wallet->fresh()->balance)->toBe(1000);
    expect($recipient->wallet->fresh()->balance)->toBe(100000);
});
