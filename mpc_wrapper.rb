module MpcWrapper
  module_function

  def current_track_info
    artist, album, title = `mpc -f '%artist%\n%album%\n%title%' current`.split("\n")
    { artist: artist,
      album: album,
      title: title }
  end

  def playlists
    `mpc lsplaylists`.split("\n")
  end

  def playlist_songs(name)
    `mpc playlist #{name}`.split("\n")
  end

  def next_track
    `mpc next`
    current_track_info
  end

  def previous_track
    `mpc prev`
    current_track_info
  end

  def play
    `mpc play`
    current_track_info
  end

  def pause
    `mpc pause`
    current_track_info
  end

  def update
    `mpc update`
    { status: :ok }
  end

  def reload
    `mpc clear && (mpc listall | mpc add)`
    { status: :ok }
  end

  # returns volume in percents
  def volume(value = nil)
    regex = /volume:\s*(\d*)%/
    status = `mpc volume #{value}`
    regex.match(status)[1].to_i
  end
end
