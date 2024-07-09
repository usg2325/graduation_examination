document.addEventListener('turbo:load', () => {
  const tbody = document.getElementById('playlist-items');
  let playlistItems = JSON.parse(tbody.getAttribute('data-playlist-items'));
  const hiddenField = document.getElementById('hidden_playlist_items');

  function moveUp(index) {
    if (index > 0) {
      const item = playlistItems[index];
      playlistItems[index] = playlistItems[index - 1];
      playlistItems[index - 1] = item;
      updatePlaylist();
    }
  }

  function moveDown(index) {
    if (index < playlistItems.length - 1) {
      const item = playlistItems[index];
      playlistItems[index] = playlistItems[index + 1];
      playlistItems[index + 1] = item;
      updatePlaylist();
    }
  }

  function removeItem(index) {
    playlistItems.splice(index, 1);
    updatePlaylist();
  }

  function updatePlaylist() {
    tbody.innerHTML = '';
    playlistItems.forEach((item, index) => {
      tbody.innerHTML += `
        <tr class="table-row">
          <td>${index +1}</td>
          <td>${item[0]}</td>
          <td>${item[1]}</td>
          <td><button type="button" class="btn btn-outline btn-secondary" onclick="moveUp(${index})" > ↑ </button></td>
          <td><button type="button" class="btn btn-outline btn-secondary" onclick="moveDown(${index})" > ↓ </button></td>
          <td><button type="button" class="btn btn-outline btn-primary" onclick="removeItem(${index})">削除</button></td>
        </tr>
      `;
    });
  }

  function syncPlaylistItems() {
    hiddenField.value = JSON.stringify(playlistItems);
  }

  window.moveUp = moveUp;
  window.moveDown = moveDown;
  window.removeItem = removeItem;
  window.syncPlaylistItems = syncPlaylistItems;
});
