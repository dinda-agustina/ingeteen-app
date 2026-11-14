<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class TaskController extends Controller
{
    /**
     * Mengambil seluruh tugas milik user yang login.
     */
    public function index(Request $request): JsonResponse
    {
        $tasks = $request->user()
            ->tasks()
            ->with('label')
            ->orderBy('deadline', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Daftar tugas berhasil diambil.',
            'data' => $tasks,
        ], 200);
    }

    /**
     * Menambahkan tugas baru.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'judul' => [
                'required',
                'string',
                'max:150',
            ],
            'deskripsi' => [
                'nullable',
                'string',
            ],
            'deadline' => [
                'required',
                'date',
            ],
            'label_id' => [
                'nullable',
                'integer',
                Rule::exists('labels', 'id')
                    ->where(fn ($query) =>
                        $query->where(
                            'user_id',
                            $request->user()->id
                        )
                    ),
            ],
            'is_completed' => [
                'sometimes',
                'boolean',
            ],
        ]);

        // Membuat tugas melalui relasi user
        // sehingga user_id otomatis mengikuti user login
        $task = $request->user()
            ->tasks()
            ->create($validated);

        $task->load('label');

        return response()->json([
            'success' => true,
            'message' => 'Tugas berhasil ditambahkan.',
            'data' => $task,
        ], 201);
    }

    /**
     * Mengambil detail satu tugas.
     */
    public function show(Request $request, int $id): JsonResponse
    {
        $task = $request->user()
            ->tasks()
            ->with('label')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Detail tugas berhasil diambil.',
            'data' => $task,
        ], 200);
    }

    /**
     * Mengubah data tugas.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        // Cari tugas berdasarkan user yang login
        $task = $request->user()
            ->tasks()
            ->findOrFail($id);

        $validated = $request->validate([
            'judul' => [
                'sometimes',
                'required',
                'string',
                'max:150',
            ],
            'deskripsi' => [
                'sometimes',
                'nullable',
                'string',
            ],
            'deadline' => [
                'sometimes',
                'required',
                'date',
            ],
            'label_id' => [
                'sometimes',
                'nullable',
                'integer',
                Rule::exists('labels', 'id')
                    ->where(fn ($query) =>
                        $query->where(
                            'user_id',
                            $request->user()->id
                        )
                    ),
            ],
            'is_completed' => [
                'sometimes',
                'boolean',
            ],
        ]);

        if (empty($validated)) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada data yang dikirim untuk diperbarui.',
            ], 422);
        }

        $task->update($validated);
        $task->load('label');

        return response()->json([
            'success' => true,
            'message' => 'Tugas berhasil diperbarui.',
            'data' => $task,
        ], 200);
    }

    /**
     * Mengubah status penyelesaian tugas.
     */
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $task = $request->user()
            ->tasks()
            ->findOrFail($id);

        $validated = $request->validate([
            'is_completed' => [
                'required',
                'boolean',
            ],
        ]);

        $task->update([
            'is_completed' => $validated['is_completed'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status tugas berhasil diperbarui.',
            'data' => $task,
        ], 200);
    }

    /**
     * Menghapus tugas.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $task = $request->user()
            ->tasks()
            ->findOrFail($id);

        $task->delete();

        return response()->json([
            'success' => true,
            'message' => 'Tugas berhasil dihapus.',
        ], 200);
    }
}
