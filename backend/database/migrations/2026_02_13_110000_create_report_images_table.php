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
        Schema::create('report_images', function (Blueprint $table) {
            $table->id();
            $table->uuid('report_id');
            $table->text('path');
            $table->text('url');
            $table->string('mime', 100);
            $table->unsignedBigInteger('size');
            $table->timestamp('created_at')->useCurrent();

            $table->foreign('report_id')
                ->references('id')
                ->on('reports')
                ->cascadeOnUpdate()
                ->cascadeOnDelete();

            $table->index(['report_id', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('report_images');
    }
};

