<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    
    // Register akun pengguna baru.
    
    public function register(Request $request): JsonResponse
    {
        // Validasi input dari pengguna
        $validated = $request->validate([
            'username' => [
                'required',
                'string',
                'min:3',
                'max:50',
                'alpha_dash',
                'unique:users,username',
            ],
            'password' => [
                'required',
                'string',
                'min:8',
                'confirmed',
            ],
            'device_name' => [
                'nullable',
                'string',
                'max:100',
            ],
        ]);

        // Membuat akun baru
        $user = User::create([
            'username' => $validated['username'],
            'password' => $validated['password'],
        ]);

        // Membuat token Sanctum
        $token = $user->createToken(
            $validated['device_name'] ?? 'IngeTeen Mobile'
        )->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registrasi berhasil.',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'username' => $user->username,
                ],
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ], 201);
    }

    // Login pengguna.
    public function login(Request $request): JsonResponse
    {
        // Validasi input login
        $validated = $request->validate([
            'username' => [
                'required',
                'string',
            ],
            'password' => [
                'required',
                'string',
            ],
            'device_name' => [
                'nullable',
                'string',
                'max:100',
            ],
        ]);

        // Mencari pengguna berdasarkan username
        $user = User::where(
            'username',
            $validated['username']
        )->first();

        // Memeriksa akun dan password
        if (
            ! $user ||
            ! Hash::check($validated['password'], $user->password)
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah.',
            ], 401);
        }

        // Membuat token untuk perangkat
        $token = $user->createToken(
            $validated['device_name'] ?? 'IngeTeen Mobile'
        )->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'username' => $user->username,
                ],
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ], 200);
    }

    
    // Logout pengguna
    public function logout(Request $request): JsonResponse
    {
        // Menghapus token yang sedang digunakan
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ], 200);
    }
}
