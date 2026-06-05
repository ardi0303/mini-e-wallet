<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTransferRequest;
use App\Models\Transfer;
use App\Models\Wallet;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;

class TransferController extends Controller
{
    public function store(StoreTransferRequest $request): RedirectResponse
    {
        $sender = $request->user();
        $recipientUserId = (int) $request->integer('recipient_user_id');
        $amount = (int) $request->integer('amount');

        if ($sender->id === $recipientUserId) {
            throw ValidationException::withMessages([
                'recipient_user_id' => 'Anda tidak dapat mentransfer ke akun sendiri.',
            ]);
        }

        if ($amount <= 0) {
            throw ValidationException::withMessages([
                'amount' => 'Nominal transfer harus lebih besar dari nol.',
            ]);
        }

        DB::transaction(function () use ($sender, $recipientUserId, $amount): void {
            $senderWallet = Wallet::query()
                ->where('user_id', $sender->id)
                ->lockForUpdate()
                ->first();

            $recipientWallet = Wallet::query()
                ->where('user_id', $recipientUserId)
                ->lockForUpdate()
                ->first();

            if (! $senderWallet instanceof Wallet) {
                throw ValidationException::withMessages([
                    'amount' => 'Wallet pengirim tidak ditemukan.',
                ]);
            }

            if (! $recipientWallet instanceof Wallet) {
                throw ValidationException::withMessages([
                    'recipient_user_id' => 'Wallet penerima tidak ditemukan.',
                ]);
            }

            if ($senderWallet->balance < $amount) {
                throw ValidationException::withMessages([
                    'amount' => 'Saldo Anda tidak mencukupi.',
                ]);
            }

            $senderWallet->decrement('balance', $amount);
            $recipientWallet->increment('balance', $amount);

            Transfer::query()->create([
                'reference_id' => 'TRF-'.Str::upper((string) Str::ulid()),
                'sender_user_id' => $sender->id,
                'sender_wallet_id' => $senderWallet->id,
                'recipient_user_id' => $recipientUserId,
                'recipient_wallet_id' => $recipientWallet->id,
                'amount' => $amount,
                'transferred_at' => now(),
            ]);
        }, 3);

        Inertia::flash('toast', [
            'type' => 'success',
            'message' => __('Transfer berhasil diproses.'),
        ]);

        return to_route('dashboard');
    }
}
