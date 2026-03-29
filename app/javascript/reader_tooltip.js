// app/javascript/reader_tooltip.js

document.addEventListener("DOMContentLoaded", function () {
  const tooltip       = document.getElementById("word-tooltip");
  const tooltipJa     = tooltip?.querySelector(".tooltip-japanese");
  const tooltipRead   = tooltip?.querySelector(".tooltip-reading");
  const tooltipEn     = tooltip?.querySelector(".tooltip-english");
  const tooltipImg    = tooltip?.querySelector(".tooltip-image");

  if (!tooltip) return;

  document.addEventListener("mouseover", function (e) {
    const target = e.target.closest(".matched-word");
    if (!target) return;

    const data = JSON.parse(target.dataset.word);

    tooltipJa.textContent   = data.japanese || "";
    tooltipRead.textContent = data.reading  || "";
    tooltipEn.textContent   = data.english  || "";

    if (data.image_url) {
      tooltipImg.src = data.image_url;
      tooltipImg.style.display = "block";
    } else {
      tooltipImg.style.display = "none";
    }

    tooltip.style.display = "block";
    positionTooltip(e);
  });

  document.addEventListener("mousemove", function (e) {
    if (tooltip.style.display === "block") {
      positionTooltip(e);
    }
  });

  document.addEventListener("mouseout", function (e) {
    const target = e.target.closest(".matched-word");
    if (target) {
      tooltip.style.display = "none";
    }
  });

  function positionTooltip(e) {
    const x = e.clientX + 15;
    const y = e.clientY + 15;

    // 画面右端・下端からはみ出さないように
    const maxX = window.innerWidth - tooltip.offsetWidth - 10;
    const maxY = window.innerHeight - tooltip.offsetHeight - 10;

    tooltip.style.left = Math.min(x, maxX) + "px";
    tooltip.style.top  = Math.min(y, maxY) + "px";
  }
});