<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\LabelController;

Route::get('/health', HealthController::class);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // Mendapatkan informasi user yang sedang login
    Route::get('/user', function (Request $request) {
        return response()->json([
            'success' => true,
            'data' => [
                'id' => $request->user()->id,
                'username' => $request->user()->username,
            ],
        ]);
    });

    Route::get('/tasks/archived', [TaskController::class, 'archived']);
    Route::get('/tasks/trash', [TaskController::class, 'trash']);

    Route::post('/tasks/{id}/archive', [TaskController::class, 'archive']);
    Route::post('/tasks/{id}/unarchive', [TaskController::class, 'unarchive']);
    Route::post('/tasks/{id}/restore', [TaskController::class, 'restore']);

    Route::delete('/tasks/{id}/force', [TaskController::class, 'forceDestroy']);

    // CRUD Task
    Route::get('/tasks', [TaskController::class, 'index']);
    Route::post('/tasks', [TaskController::class, 'store']);
    Route::get('/tasks/{id}', [TaskController::class, 'show']);
    Route::patch('/tasks/{id}', [TaskController::class, 'update']);
    Route::patch('/tasks/{id}/status', [TaskController::class, 'updateStatus']);
    Route::delete('/tasks/{id}', [TaskController::class, 'destroy']);


    // CRUD Label
    Route::get('/labels', [LabelController::class, 'index']);
    Route::post('/labels', [LabelController::class, 'store']);
    Route::get('/labels/{id}', [LabelController::class, 'show']);
    Route::patch('/labels/{id}', [LabelController::class, 'update']);
    Route::delete('/labels/{id}', [LabelController::class, 'destroy']);

});