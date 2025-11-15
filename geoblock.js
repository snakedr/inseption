<!-- GEO BLOCK SCRIPT -->
<script>
  // Проверяем, что мы не на локальном сервере
  if (location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') {
    fetch('https://ipapi.co/json/')
      .then(response => response.json())
      .then(data => {
        const country = data.country; // Код страны (например, "RU", "DE")
        const ip = data.ip; // Для отладки

        console.log('Geo Debug: IP =', ip, 'Country =', country);

        if (country !== 'RU') {
          // Блокируем доступ для всех, кроме России
          document.body.innerHTML = `
            <div style="text-align:center; margin-top:50px; color:red; font-size:24px;">
              Access is denied for your region.
              <p style="font-size:18px; color:#333;">Your IP: ${ip}, Detected Country: ${country}</p>
              <button onclick="location.reload()" style="margin-top:20px; padding:10px 20px; font-size:16px;">Try again</button>
            </div>
          `;
        } else {
          console.log('Geo Debug: Доступ разрешён для RU.');
        }
      })
      .catch(error => {
        console.error('Ошибка при определении геолокации:', error);
        // ВАЖНО: Не блокируем доступ при ошибке!
        console.log('Geo Debug: Ошибка геолокации, доступ разрешён для безопасности.');
        // Если геолокация не удалась, НЕ БЛОКИРУЕМ.
        // Это предотвращает блокировку при ошибках API.
      });
  } else {
    console.log('Geo Debug: Локальный хост, скрипт геоблокировки отключен.');
  }
</script>
