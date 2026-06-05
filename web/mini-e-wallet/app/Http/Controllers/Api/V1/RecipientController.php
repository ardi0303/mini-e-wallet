<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\UserResource;
use App\Models\User;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class RecipientController extends Controller
{
    public function __invoke(): AnonymousResourceCollection
    {
        $user = request()->user();

        $recipients = User::query()
            ->with('wallet')
            ->select(['id', 'uuid', 'name', 'email'])
            ->whereKeyNot($user->id)
            ->whereHas('wallet')
            ->orderBy('name')
            ->get();

        return UserResource::collection($recipients);
    }
}
