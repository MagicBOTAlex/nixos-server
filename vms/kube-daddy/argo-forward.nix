{
  pkgs,
  ...
}:
{
  systemd.services."argo-forward" = {
    description = "forwards argo running on kubernetes";

    after = [
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      sleep 30
      ${pkgs.kubernetes}/bin/kubectl patch cm argocd-cmd-params-cm -n argocd --type merge --patch '{"data":{"server.insecure": "true", "url":"https://argocd.deprived.dev"}}'
      ${pkgs.kubernetes}/bin/kubectl -n argocd rollout restart deployment argocd-repo-server
      ${pkgs.kubernetes}/bin/kubectl port-forward svc/argocd-server -n argocd 4325:443 --address 0.0.0.0 || true
    '';

    serviceConfig = {
      User = "root";
      Restart = "always";
    };
  };
}
