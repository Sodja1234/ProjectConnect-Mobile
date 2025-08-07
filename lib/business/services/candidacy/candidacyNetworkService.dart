abstract class CandidacyNetworkService{

  Future<bool?> applyForRole(int roleId,String token);
  Future<bool?> inviteForRole(int roleId,String token,String email);
}