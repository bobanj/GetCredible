class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:endorse]
  before_filter :load_user, :only => [:show, :followers, :following, :endorse]

  def index
    @users = User.search(params)

    render 'index', layout: (request.xhr? ? false : true)
  end

  def show
    @user_tags = @user.user_tags.joins(:tag, :endorsements => :endorser).group("user_tags.id")
    #@user_tags = @user_tags.sort_by{ |ut| - ut.endorsements.length }
    render :layout => false if request.xhr?
  end

  def followers
    @users = @user.voters.order_by_name.
      paginate :per_page => 10, :page => params[:page]

    render :users, layout: (request.xhr? ? false : true)
  end

  def following
    @users = @user.voted_users.order_by_name.
      paginate :per_page => 10, :page => params[:page]

    render :users, layout: (request.xhr? ? false : true)
  end

  def endorse
    tag_name = TagCleaner.clean(params[:tag])
    @user_endorsement = Endorsement.new
    @user_endorsement.description = params[:description]
    @user_endorsement.endorsed_by_id = current_user.id
    tag = @user.tags.find_by_name tag_name
    @already_has_tag = tag ? true : false
    if tag_name
      current_user.add_tags(@user, tag_name, :skip_email => true)
      tag = @user.tags.find_by_name tag_name
      if tag
        @user_tag = @user.user_tags.where(:tag_id => tag.id).first
        @user_endorsement.user_tag_id = @user_tag.id if @user_tag
      end
    end
    if @user_endorsement.save
      current_user.activity_items.create(:item => @user_endorsement, :target_id => @user.id)
      UserMailer.endorse_email(@user_endorsement).deliver
      render :endorsement_success
    else
      render :endorsement_failure
    end
  end

  private
  def load_user
    @user = User.find_by_username!(params[:id])
  end
end
