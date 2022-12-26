import { encodeAddress } from "@polkadot/keyring";

function formatAddress(address, network, cutOff) {
  if (!address) {
    return "";
  }

  cutOff = cutOff ?? true;
  network = network ?? "Polkdaot";
  const format = network === "Polkadot" ? 0 : 2;

  let addressFormatted;

  try {
    addressFormatted = encodeAddress(address, format) ?? address;
  } catch {
    addressFormatted = address;
  }

  if (cutOff) {
    return `${addressFormatted.slice(0, 6)}...${addressFormatted.slice(
      addressFormatted.length - 6
    )}`;
  }

  return addressFormatted;
}

customElements.define(
  "address-input",
  class extends HTMLElement {
    // things required by Custom Elements
    constructor() {
      super();
    }
    connectedCallback() {
      this.setTextContent();
    }
    attributeChangedCallback() {
      this.setTextContent();
    }
    static get observedAttributes() {
      return ["address", "network"];
    }

    // Our function to set the textContent based on attributes.
    setTextContent() {
      const address = this.getAttribute("address");
      const network = this.getAttribute("network");
      const cutOff = this.getAttribute("cut-off");

      this.setAttribute()
      this.textContent = formatAddress(address, network, cutOff);
    }
  }
);
