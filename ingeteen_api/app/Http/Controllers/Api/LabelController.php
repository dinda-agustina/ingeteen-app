<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class LabelController extends Controller
{
    /**
     * Mengambil seluruh label milik user yang login.
     */
    public function index(Request $request): JsonResponse
    {
        $labels = $request->user()
            ->labels()
            ->withCount('tasks')
            ->orderBy('nama_label', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar label berhasil diambil.',
            'data' => $labels,
        ], 200);
    }

    /**
     * Menambahkan label baru.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nama_label' => [
                'required',
                'string',
                'max:100',
                Rule::unique('labels', 'nama_label')
                    ->where(fn ($query) =>
                        $query->where(
                            'user_id',
                            $request->user()->id
                        )
                    ),
            ],
            'kode_warna' => [
                'required',
                'string',
                'regex:/^#[0-9A-Fa-f]{6}$/',
            ],
        ]);

        // Membuat label melalui relasi user
        $label = $request->user()
            ->labels()
            ->create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Label berhasil ditambahkan.',
            'data' => $label->refresh(),
        ], 201);
    }

    /**
     * Mengambil detail satu label.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $label = $request->user()
            ->labels()
            ->withCount('tasks')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Detail label berhasil diambil.',
            'data' => $label,
        ], 200);
    }

    /**
     * Mengubah data label.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        // Hanya mencari label milik user yang login
        $label = $request->user()
            ->labels()
            ->findOrFail($id);

        $validated = $request->validate([
            'nama_label' => [
                'sometimes',
                'required',
                'string',
                'max:100',
                Rule::unique('labels', 'nama_label')
                    ->where(fn ($query) =>
                        $query->where(
                            'user_id',
                            $request->user()->id
                        )
                    )
                    ->ignore($label->id),
            ],
            'kode_warna' => [
                'sometimes',
                'required',
                'string',
                'regex:/^#[0-9A-Fa-f]{6}$/',
            ],
        ]);

        if (empty($validated)) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada data yang dikirim untuk diperbarui.',
            ], 422);
        }

        $label->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Label berhasil diperbarui.',
            'data' => $label->refresh(),
        ], 200);
    }

    /**
     * Menghapus label.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $label = $request->user()
            ->labels()
            ->findOrFail($id);

        $label->delete();

        return response()->json([
            'success' => true,
            'message' => 'Label berhasil dihapus.',
        ], 200);
    }
}
