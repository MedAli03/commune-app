<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('reports', function (Blueprint $table) {
            $table->string('id', 36)->primary();
            $table->string('title', 255);
            $table->text('description');
            $table->text('photo_path')->nullable();
            $table->double('latitude')->nullable();
            $table->double('longitude')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->nullable()->useCurrentOnUpdate();

            $table->index('created_at', 'idx_reports_created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};
