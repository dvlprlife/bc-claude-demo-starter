# Make a release

The README download link points to the asset `bc-claude-demo-starter.zip` of the latest release. Use this name for the asset.

1. Make the repository public before the first release. Attendees cannot download from a private repository.
2. Make the zip from the committed files. The zip has one top folder, `bc-claude-demo-starter/`:

   ```powershell
   git archive --format=zip --prefix=bc-claude-demo-starter/ -o bc-claude-demo-starter.zip HEAD
   ```

3. Create the release with the zip as an asset:

   ```powershell
   gh release create v1.0.0 bc-claude-demo-starter.zip --title "Version 1.0.0" --notes "First release of the starter kit."
   ```

4. Test the link: <https://github.com/dvlprlife/bc-claude-demo-starter/releases/latest/download/bc-claude-demo-starter.zip>
