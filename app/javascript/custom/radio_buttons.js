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
