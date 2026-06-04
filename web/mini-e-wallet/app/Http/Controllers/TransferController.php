<?php

namespace App\Http\Controllers;

use App\Actions\TransferFundsAction;
use App\Http\Requests\StoreTransferRequest;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;

class TransferController extends Controller
{
    public function store(StoreTransferRequest $request, TransferFundsAction $transferFunds): RedirectResponse
    {
        $transferFunds->handle(
            sender: $request->user(),
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
