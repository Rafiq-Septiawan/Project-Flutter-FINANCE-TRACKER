<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'name',
        'type',
        'icon',
        'color'
    ];

    // Relasi ke User
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi ke Transaction
    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }

    // Relasi ke Budget
    public function budgets()
    {
        return $this->hasMany(Budget::class);
    }
}