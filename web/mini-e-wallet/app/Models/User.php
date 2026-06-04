<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Support\Str;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

#[Fillable(['uuid', 'name', 'email', 'password'])]
#[Hidden(['password', 'two_factor_secret', 'two_factor_recovery_codes', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (self $user): void {
            $user->uuid ??= (string) Str::uuid();
        });

        static::created(function (self $user): void {
            $user->wallet()->firstOrCreate([], ['balance' => 0]);
        });
    }

    public function wallet(): HasOne
    {
        return $this->hasOne(Wallet::class);
    }

    public function sentTransfers(): HasMany
    {
        return $this->hasMany(Transfer::class, 'sender_user_id');
    }

    public function receivedTransfers(): HasMany
    {
        return $this->hasMany(Transfer::class, 'recipient_user_id');
    }
}
