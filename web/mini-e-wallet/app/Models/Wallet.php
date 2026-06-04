<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

#[Fillable(['uuid', 'user_id', 'balance'])]
class Wallet extends Model
{
    protected function casts(): array
    {
        return [
            'balance' => 'integer',
        ];
    }

    protected static function booted(): void
    {
        static::creating(function (self $wallet): void {
            $wallet->uuid ??= (string) Str::uuid();
        });
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
