<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('label_id')->nullable()->constrained()->nullOnDelete();
            $table->string('judul',150);
            $table->text('deskripsi')->nullable();
            $table->dateTime('deadline');
            $table->boolean('is_completed')->default(false);
            $table->timestamps();
            $table->index(['user_id','deadline']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tasks');
    }
};
