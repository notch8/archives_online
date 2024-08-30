# frozen_string_literal: true

Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  ##### REMOVE SEARCH HISTORY #####
  # Note: has to be before we mount Blacklight::Engine
  get '/search_history', to: 'application#render404'
  delete '/search_history/clear', to: 'application#render404'

  mount Blacklight::Engine => '/'
  mount Arclight::Engine => '/'

  root to: 'arclight/repositories#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end
  devise_for :users

  concern :exportable, Blacklight::Routes::Exportable.new
  concern :hierarchy, Arclight::Routes::Hierarchy.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :hierarchy
    concerns :exportable
  end

  ##### REMOVE BOOKMARK #####
  # resources :bookmarks do
  #   concerns :exportable
  #   collection do
  #     delete 'clear'
  #   end
  # end

  get '/about', to: 'pages#about', as: 'about'
  get '/contribute', to: 'pages#contribute', as: 'contribute'
  get '/help', to: 'pages#help', as: 'help'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
