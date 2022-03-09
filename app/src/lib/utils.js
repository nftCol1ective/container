
export function decodeTokenUri(uri) {
  const decoded = atob(uri.split(',')[1]);
  const metadata = JSON.parse(decoded);
  metadata.image = atob(metadata.image.split(',')[1]);

  return metadata;
}
