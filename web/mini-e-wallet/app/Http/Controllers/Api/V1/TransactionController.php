<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\TransferResource;
use App\Models\Transfer;
use Illuminate\Http\JsonResponse;

class TransactionController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $user = request()->user();
        $sort = request()->string('sort')->lower()->value() === 'asc' ? 'asc' : 'desc';

        $transfers = Transfer::query()
            ->with(['sender:id,uuid,name', 'recipient:id,uuid,name'])
            ->where(fn ($query) => $query
                ->where('sender_user_id', $user->id)
                ->orWhere('recipient_user_id', $user->id))
            ->orderBy('transferred_at', $sort)
            ->paginate((int) request()->integer('per_page', 10))
            ->withQueryString();

        return response()->json([
            'data' => TransferResource::collection($transfers->getCollection()),
            'meta' => [
                'current_page' => $transfers->currentPage(),
                'last_page' => $transfers->lastPage(),
                'per_page' => $transfers->perPage(),
                'total' => $transfers->total(),
                'from' => $transfers->firstItem(),
                'to' => $transfers->lastItem(),
                'sort' => $sort,
                'prev_page_url' => $transfers->previousPageUrl(),
                'next_page_url' => $transfers->nextPageUrl(),
            ],
        ]);
    }
}
