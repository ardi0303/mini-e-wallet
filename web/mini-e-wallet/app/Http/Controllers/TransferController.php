<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTransferRequest;
use App\Http\Controllers\Concerns\HandlesTransfers;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;

class TransferController extends Controller
{
    use HandlesTransfers;

    public function store(StoreTransferRequest $request): RedirectResponse
    {
        $this->handleTransfer(
            senderId: $request->user()->id,
            recipientUserId: (int) $request->integer('recipient_user_id'),
            amount: (int) $request->integer('amount'),
        );

        Inertia::flash('toast', [
            'type' => 'success',
            'message' => __('Transfer berhasil diproses.'),
        ]);

        return to_route('dashboard');
    }
}
