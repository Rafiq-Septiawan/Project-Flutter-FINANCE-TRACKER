<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\DashboardController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    
    // Category routes
    Route::apiResource('categories', CategoryController::class);
    
    // Transaction routes
    Route::apiResource('transactions', TransactionController::class);
    
    // Budget routes
    Route::apiResource('budgets', BudgetController::class);
    
    // Dashboard routes
    Route::get('/dashboard/summary', [DashboardController::class, 'summary']);
    Route::get('/dashboard/monthly-report', [DashboardController::class, 'monthlyReport']);
});