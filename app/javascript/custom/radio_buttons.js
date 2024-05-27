document.addEventListener('turbo:load', () => {
  const radioButtons = document.querySelectorAll('input[type="radio"][name="favorite_artist[artist_id]"]');
  const hiddenField = document.querySelector('input[type="hidden"][name="favorite_artist[artist_name]"]');

  radioButtons.forEach(radioButton => {
    radioButton.addEventListener('change', (event) => {
      const artistName = event.target.getAttribute('data-artist-name');
      hiddenField.value = artistName;
    });
  });
});

document.addEventListener('turbo:load', () => {
  const radioButtons = document.querySelectorAll('input[type="radio"][name="favorite_track[track_id]"]');
  const hiddenFieldName = document.querySelector('input[type="hidden"][name="favorite_track[track_name]"]');
  const hiddenFieldArtist = document.querySelector('input[type="hidden"][name="favorite_track[artist_name]"]');

  radioButtons.forEach(radioButton => {
    radioButton.addEventListener('change', (event) => {
      const trackName = event.target.getAttribute('data-track-name');
      const trackArtist = event.target.getAttribute('data-artist-name');
      hiddenFieldName.value = trackName;
      hiddenFieldArtist.value = trackArtist;
    });
  });
});
