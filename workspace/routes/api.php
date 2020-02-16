<?php

use Illuminate\Http\Request;
use App\Http\Resources\Youtubevideo;
use App\Models\Youtubevideo as yt;
//use App\Http\Controllers\API;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/


Route::post('login', 'API\UserController@login');
Route::post('register', 'API\UserController@register');
Route::group(['middleware' => 'auth:api'], function(){
Route::post('details', 'API\UserController@details');

});

Route::get('/hello',function(){
    return [
        "ab" => "cd",
    ];
});
Route::get('/hello',function(){
    $kk = yt::find(1);
    return $kk;
});