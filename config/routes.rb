Rails.application.routes.draw do
  resources :groups do
    resources :assign_rules, :only => [:new, :edit, :create, :update, :destroy]
  end
end
