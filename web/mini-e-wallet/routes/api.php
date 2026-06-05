<?php

use App\Http\Controllers\Api\V1\Auth\LoginController;
use App\Http\Controllers\Api\V1\Auth\LogoutController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\RecipientController;
use App\Http\Controllers\Api\V1\TransactionController;
use App\Http\Controllers\Api\V1\TransferController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::post('/auth/login', LoginController::class)->name('api.v1.auth.login');

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('/auth/logout', LogoutController::class)->name('api.v1.auth.logout');
        Route::get('/dashboard', DashboardController::class)->name('api.v1.dashboard');
        Route::get('/recipients', RecipientController::class)->name('api.v1.recipients.index');
        Route::get('/transactions', TransactionController::class)->name('api.v1.transactions.index');
        Route::post('/transfers', [TransferController::class, 'store'])->name('api.v1.transfers.store');
    });
});
