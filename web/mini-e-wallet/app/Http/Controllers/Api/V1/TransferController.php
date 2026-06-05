<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Concerns\HandlesTransfers;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransferRequest;
use App\Http\Resources\Api\V1\TransferResource;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class TransferController extends Controller
{
    use HandlesTransfers;

    public function store(StoreTransferRequest $request): JsonResponse
    {
        $transfer = $this->handleTransfer(
            senderId: $request->user()->id,
            recipientUserId: (int) $request->integer('recipient_user_id'),
            amount: (int) $request->integer('amount'),
        );

        $request->user()->load('wallet');

        return response()->json([
            'message' => 'Transfer berhasil diproses.',
            'data' => TransferResource::make($transfer->load([
                'sender:id,uuid,name',
                'recipient:id,uuid,name',
            ])),
            'wallet' => [
                'uuid' => $request->user()->wallet?->uuid,
                'balance' => $request->user()->wallet?->balance ?? 0,
            ],
        ], Response::HTTP_CREATED);
    }
}
