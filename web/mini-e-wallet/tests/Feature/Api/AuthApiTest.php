<?php

use App\Models\User;
use Laravel\Sanctum\Sanctum;

test('user can login via api and receive bearer token', function () {
    $user = User::factory()->create([
        'email' => 'usera@example.com',
        'password' => 'password',
    ]);

    $response = $this->postJson('/api/v1/auth/login', [
        'email' => 'usera@example.com',
        'password' => 'password',
    ]);

    $response
        ->assertOk()
        ->assertJsonPath('message', 'Login berhasil.')
        ->assertJsonPath('token_type', 'Bearer')
        ->assertJsonPath('user.email', 'usera@example.com');

    expect($response->json('token'))->not->toBeEmpty();
});

test('authenticated user can fetch api profile summary', function () {
    $user = User::factory()->create();

    Sanctum::actingAs($user);

    $this->getJson('/api/v1/dashboard')
        ->assertOk()
        ->assertJsonPath('data.user.id', $user->id)
        ->assertJsonStructure([
            'data' => [
                'user' => [
                    'id',
                    'uuid',
                    'name',
                    'email',
                    'wallet' => ['uuid', 'balance'],
                ],
            ],
        ]);
});
