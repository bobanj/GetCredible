module PreloaderHelper
  def preload_activity_items(activity_items)
    ActiveRecord::Associations::Preloader.
      new(activity_items, [:target, :user, :tags, :item]).run
  end
end
