<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Helpers\CategoryHelper;

class CreateUserCategories extends Command
{
    protected $signature = 'user:create-categories {email}';
    protected $description = 'Create default categories for specific user';

    public function handle()
    {
        $email = $this->argument('email');
        $user = User::where('email', $email)->first();

        if (!$user) {
            $this->error("User dengan email {$email} tidak ditemukan!");
            return;
        }

        CategoryHelper::createDefaultCategories($user->id);
        
        $this->info("✅ Kategori berhasil dibuat untuk user: {$user->name} ({$user->email})");
    }
}