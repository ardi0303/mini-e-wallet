<?php

use App\Http\Controllers\DashboardController;
use App\Http\Controllers\TransferController;
use Illuminate\Support\Facades\Route;

Route::inertia('/', 'welcome')->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', DashboardController::class)->name('dashboard');
    Route::post('transfers', [TransferController::class, 'store'])->name('transfers.store');
});

require __DIR__.'/settings.php';
