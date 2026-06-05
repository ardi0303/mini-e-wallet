<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransferResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $userId = $request->user()?->id;
        $isOutgoing = $this->sender_user_id === $userId;
        $counterparty = $isOutgoing ? $this->recipient : $this->sender;

        return [
            'uuid' => $this->uuid,
            'reference_id' => $this->reference_id,
            'type' => $isOutgoing ? 'outgoing' : 'incoming',
            'amount' => $this->amount,
            'transferred_at' => $this->transferred_at?->toIso8601String(),
            'counterparty' => [
                'uuid' => $counterparty?->uuid,
                'name' => $counterparty?->name,
            ],
        ];
    }
}
