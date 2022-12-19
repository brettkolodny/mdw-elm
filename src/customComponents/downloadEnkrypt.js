function checkBrowser() {
  // Get the user-agent string
  let userAgentString = navigator.userAgent;

  // Detect Chrome
  let chromeAgent = userAgentString.indexOf("Chrome") > -1;

  // Detect Internet Explorer
  let IExplorerAgent =
    userAgentString.indexOf("MSIE") > -1 || userAgentString.indexOf("rv:") > -1;

  // Detect Firefox
  let firefoxAgent = userAgentString.indexOf("Firefox") > -1;

  // Detect Safari
  let safariAgent = userAgentString.indexOf("Safari") > -1;

  // Discard Safari since it also matches Chrome
  if (chromeAgent && safariAgent) safariAgent = false;

  // Detect Opera
  let operaAgent = userAgentString.indexOf("OP") > -1;

  // Discard Chrome since it also matches Opera
  if (chromeAgent && operaAgent) chromeAgent = false;

  if (safariAgent) return "safari";
  if (chromeAgent) return "chrome";
  if (IExplorerAgent) return "internet-explorer";
  if (operaAgent) return "opera";
  if (firefoxAgent) return "firefox";

  return "chrome";
}

function getTextAndDownloadLink() {
  switch (checkBrowser()) {
    case "safari":
      return [
        "Safari",
        "https://apps.apple.com/app/enkrypt-web3-wallet/id1640164309",
      ];
    case "chrome":
      return [
        "Chrome",
        "https://chrome.google.com/webstore/detail/enkrypt/kkpllkodjeloidieedojogacfhpaihoh",
      ];

    case "internet-explorer":
      break;
    case "opera":
      return [
        "Opera",
        "https://microsoftedge.microsoft.com/addons/detail/gfenajajnjjmmdojhdjmnngomkhlnfjl",
      ];
    case "firefox":
      return [
        "Firefox",
        "https://addons.mozilla.org/en-US/firefox/addon/enkrypt/",
      ];

    default:
      return [
        "Chrome",
        "https://chrome.google.com/webstore/detail/enkrypt/kkpllkodjeloidieedojogacfhpaihoh",
      ];
  }
}

customElements.define(
  "download-link",
  class extends HTMLElement {
    // things required by Custom Elements
    constructor() {
      super();
    }
    connectedCallback() {
      this.setTextContent();
      this.appendChild;
    }
    attributeChangedCallback() {
      this.setTextContent();
    }

    // Our function to set the textContent based on attributes.
    setTextContent() {
      const [browser, link] = getTextAndDownloadLink();
      this.textContent = `Get on the ${browser} web store`;
      this.onclick = () => {
        window.open(link, "_blank");
      };
    }
  }
);
