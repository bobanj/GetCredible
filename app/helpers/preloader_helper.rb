module PreloaderHelper
  def preload_activity_items(activity_items)
    ActiveRecord::Associations::Preloader.
      new(activity_items, [:target, :user, :tags]).run
  end
end
