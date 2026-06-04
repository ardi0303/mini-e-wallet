<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $users = [
            [
                'name' => 'User A',
                'email' => 'usera@example.com',
                'password' => Hash::make('password'),
            ],
            [
                'name' => 'User B',
                'email' => 'userb@example.com',
                'password' => Hash::make('password'),
            ],
            [
                'name' => 'User C',
                'email' => 'userc@example.com',
                'password' => Hash::make('password'),
            ],
        ];

        foreach ($users as $userData) {
            $user = User::query()->updateOrCreate(
                ['email' => $userData['email']],
                $userData,
            );

            Wallet::query()->updateOrCreate(
                ['user_id' => $user->id],
                ['balance' => 100000],
            );
        }
    }
}
