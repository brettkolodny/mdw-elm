import Identicon from "@polkadot/react-identicon";
import React from "react";
import * as ReactDOM from "react-dom/client";

customElements.define(
  "address-identicon",
  class XSearch extends HTMLElement {
    connectedCallback() {
      const address = this.getAttribute("address");

      const mountPoint = document.createElement("span");

      this.appendChild(mountPoint);

      const root = ReactDOM.createRoot(mountPoint);

      root.render(<Identicon value={address} size={32} theme="polkadot" />);
    }
    Ï;
  }
);
