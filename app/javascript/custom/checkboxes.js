document.addEventListener('turbo:load', () => {
  const checkMax = 5;
  const checkBoxes = document.querySelectorAll('input[name="create_genre[genre_ids][]"]');

  checkBoxes.forEach((checkbox) => {
    checkbox.addEventListener('change', () => {
      const checkedCheckboxes = document.querySelectorAll('input[name="create_genre[genre_ids][]"]:checked');
      if (checkedCheckboxes.length >= checkMax) {
        checkBoxes.forEach((cb) => {
          if (!cb.checked) {
            cb.disabled = true;
          }
        });
      } else {
        checkBoxes.forEach((cb) => {
          cb.disabled = false;
        });
      }
    });
  });
});

document.addEventListener('turbo:load', () => {
  const checkMax = 5;
  const checkBoxes = document.querySelectorAll('input[name="create_artist[artist_ids][]"]');

  checkBoxes.forEach((checkbox) => {
    checkbox.addEventListener('change', () => {
      const checkedCheckboxes = document.querySelectorAll('input[name="create_artist[artist_ids][]"]:checked');
      if (checkedCheckboxes.length >= checkMax) {
        checkBoxes.forEach((cb) => {
          if (!cb.checked) {
            cb.disabled = true;
          }
        });
      } else {
        checkBoxes.forEach((cb) => {
          cb.disabled = false;
        });
      }
    });
  });
});
