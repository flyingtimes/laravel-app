<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateYoutubevideosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('youtubevideos', function (Blueprint $table) {
            $table->increments('id');
            $table->string('title')->comment('视频标题')->nullable();
            $table->string('category')->comment('分类')->nullable();
            $table->string('url')->comment('地址')->nullable();
            $table->float('size')->comment('大小')->nullable();
            $table->string('description')->comment('内容简介')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('youtubevideos');
    }
}
