<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Throwable;

class HealthController extends Controller
{
    public function __invoke(): JsonResponse
    {
        try {
            DB::connection()->getPdo();

            return response()->json([
                'success' => true,
                'message' => 'IngeTeen API is running.',
                'data' => [
                    'api' => 'ok',
                    'database' => 'connected',
                ],
            ], 200);

        } catch (Throwable $exception) {

            report($exception);

            return response()->json([
                'success' => false,
                'message' => 'Database connection failed.',
                'data' => [
                    'api' => 'ok',
                    'database' => 'disconnected',
                ],
            ], 503);
        }
    }
}