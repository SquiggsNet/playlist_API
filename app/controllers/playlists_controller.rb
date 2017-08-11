include ActionController::HttpAuthentication::Token::ControllerMethods
class PlaylistsController < ApplicationController
  before_filter :restrict_access
  before_action :set_playlist, only: [:show, :update, :destroy]

  # GET /playlists
  def index
    # @playlists = Playlist.all.order(Name: :asc)
    @playlists = Playlist.joins(:api_key).where('ApiKeyId' => params[:ApiKeyId]).order(Name: :asc)

    render json: @playlists
    # render json: @playlists, include: ['tracks']
  end

  # GET /playlists/1
  def show
    render json: @playlist, include: ['tracks']
  end

  # POST /playlists
  def create
    # @playlist = Playlist.new(playlist_params)
    @playlist = Playlist.new(Name: params[:Name], ApiKeyId: params[:ApiKeyId])
    # @playlist.api_key = ApiKey.find(params[:ApiKeyId])

    if @playlist.save
      add_tracks_to_playlist
      render json: @playlist, include: ['tracks'], status: :created, location: @playlist
    else
      render json: @playlist.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /playlists/1
  def update
    if @playlist.update(Name: params[:Name], ApiKeyId: params[:ApiKeyId])
      add_tracks_to_playlist
      render json: @playlist, include: ['tracks']
    else
      render json: @playlist.errors, status: :unprocessable_entity
    end
  end

  # DELETE /playlists/1
  def destroy
    @playlist.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playlist
      @playlist = Playlist.find(params[:id])
    end

    def add_tracks_to_playlist
      if(params[:TrackId].present?)
        @track = Track.find(params[:TrackId].split(','))
        @playlist.tracks = @track
      end
    end

    # Only allow a trusted parameter "white list" through.
    def playlist_params
      params.permit(:PlaylistID, :Name, :TrackId, :ApiKeyId )
    end

    def restrict_access
      authenticate_or_request_with_http_token do |token, options|
        ApiKey.exists?(access_token: token)
      end
    end
end
