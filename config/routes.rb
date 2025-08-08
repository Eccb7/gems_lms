Rails.application.routes.draw do
  devise_for :users

  # Landing page for non-authenticated users
  get "landing", to: "pages#landing"

  # Redirect root based on authentication status
  authenticated :user do
    root "home#index", as: :authenticated_root
  end

  unauthenticated do
    root "pages#landing"
  end

  # Static pages
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "privacy", to: "pages#privacy"
  get "terms", to: "pages#terms"

  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA manifest and service worker
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Public course browsing
  resources :courses, only: [ :index, :show ] do
    member do
      post :enroll
      delete :leave
    end

    # Payment routes for courses
    resources :payments, only: [ :create ]
  end

  # Payment management routes
  resources :payments, only: [ :index, :show ] do
    member do
      get :mpesa_checkout
      get :check_payment_status
    end
  end

  # M-Pesa callback route
  post "mpesa/callback", to: "payments#mpesa_callback", as: :mpesa_callback

  resources :categories, only: [ :index, :show ]

  # Student dashboard (direct access)
  get "students/dashboard", to: "students#dashboard", as: :student_dashboard

  # Student namespace
  namespace :student do
    get "dashboard", to: "dashboard#index"
    resources :courses, only: [ :index, :show ] do
      resources :lessons, only: [ :show ] do
        member do
          post :complete
        end
        resources :quizzes, only: [ :show ] do
          resources :quiz_attempts, only: [ :create, :show, :update ] do
            member do
              post :submit
            end
          end
        end
        resources :assignments, only: [ :show ] do
          resources :assignment_submissions, except: [ :index, :destroy ]
        end
      end
    end
    resources :notifications, only: [ :index, :show, :update ] do
      collection do
        post :mark_all_as_read
      end
    end
  end

  # Instructor namespace
  namespace :instructor do
    get "dashboard", to: "dashboard#index"
    resources :courses do
      member do
        patch :publish
        get :analytics
      end
      resources :sections do
        resources :lessons do
          resources :quizzes do
            resources :quiz_questions do
              resources :quiz_options, except: [ :show ]
            end
          end
          resources :assignments
        end
      end
      resources :enrollments, only: [ :index, :show ]
      resources :assignment_submissions, only: [ :index, :show, :update ] do
        member do
          patch :grade
          patch :return_for_revision
        end
      end
    end
    resources :notifications, only: [ :index, :show ]
  end

  # Admin namespace
  namespace :admin do
    get "dashboard", to: "dashboard#index"
    get "analytics", to: "dashboard#analytics"

    resources :users do
      member do
        patch :activate
        patch :deactivate
        patch :change_role
      end
    end

    resources :courses do
      member do
        patch :approve
        patch :reject
        patch :archive
      end
    end

    resources :categories

    resources :notifications, only: [ :index, :new, :create, :show, :destroy ] do
      collection do
        post :send_announcement
      end
    end

    resources :reports, only: [ :index ] do
      collection do
        get :users
        get :courses
        get :enrollments
        get :revenue
      end
    end
  end

  # API namespace for future mobile app or integrations
  namespace :api do
    namespace :v1 do
      resources :courses, only: [ :index, :show ]
      resources :lessons, only: [ :show ]
      # Add more API endpoints as needed
    end
  end
end
