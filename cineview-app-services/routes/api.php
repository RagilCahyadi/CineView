<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\WatchlistController;
use App\Http\Controllers\Api\ReviewController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/reviews/movie/{movie_id}', [ReviewController::class, 'getByMovie']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // User Profile Routes
    Route::get('/user', [AuthController::class, 'getProfile']);
    Route::post('/user/update', [AuthController::class, 'updateProfile']);
    Route::post('/user/change-password', [AuthController::class, 'changePassword']);

    // Watchlist Routes
    Route::get('/watchlist', [WatchlistController::class, 'index']);
    Route::post('/watchlist', [WatchlistController::class, 'store']);
    Route::delete('/watchlist/{id}', [WatchlistController::class, 'destroy']);
    Route::get('/watchlist/check/{movie_id}', [WatchlistController::class, 'check']);

    // Review Routes
    Route::get('/reviews', [ReviewController::class, 'index']);
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::get('/reviews/{movie_id}', [ReviewController::class, 'show']);
    Route::match(['put', 'post'], '/reviews/{id}', [ReviewController::class, 'update']);
    Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);
});


Route::get('/users', [AuthController::class, 'index']);