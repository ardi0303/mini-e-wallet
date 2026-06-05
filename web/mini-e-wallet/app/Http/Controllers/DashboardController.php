<?php

namespace App\Http\Controllers;

use App\Models\Transfer;
use App\Models\User;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function __invoke(Request $request): Response
    {
        $user = $request->user()->load('wallet');
        $sort = $request->string('sort')->lower()->value() === 'asc' ? 'asc' : 'desc';

        $transfers = Transfer::query()
            ->with(['sender:id,name', 'recipient:id,name'])
            ->where(fn ($query) => $query
                ->where('sender_user_id', $user->id)
                ->orWhere('recipient_user_id', $user->id))
            ->orderBy('transferred_at', $sort)
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('dashboard/index', [
            'wallet' => [
                'uuid' => $user->wallet?->uuid,
                'balance' => $user->wallet?->balance ?? 0,
            ],
            'transferForm' => [
                'recipients' => User::query()
                    ->select(['id', 'uuid', 'name', 'email'])
                    ->whereKeyNot($user->id)
                    ->whereHas('wallet')
                    ->orderBy('name')
                    ->get(),
            ],
            'transactions' => [
                'data' => $transfers->getCollection()
                    ->map(fn (Transfer $transfer) => [
                        'uuid' => $transfer->uuid,
                        'reference_id' => $transfer->reference_id,
                        'type' => $transfer->sender_user_id === $user->id ? 'outgoing' : 'incoming',
                        'counterparty_name' => $transfer->sender_user_id === $user->id
                            ? $transfer->recipient?->name
                            : $transfer->sender?->name,
                        'amount' => $transfer->amount,
                        'transferred_at' => $transfer->transferred_at?->toIso8601String(),
                    ])
                    ->values(),
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
            ],
        ]);
    }
}
