<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\UserResource;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $user = request()->user()->load('wallet');

        return response()->json([
            'data' => [
                'user' => UserResource::make($user),
            ],
        ]);
    }
}
