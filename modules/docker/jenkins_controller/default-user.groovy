import jenkins.model.*
import hudson.security.*

def env = System.getenv()

def jenkins = Jenkins.getInstance()
if(!(jenkins.getSecurityRealm() instanceof HudsonPrivateSecurityRealm))
    jenkins.setSecurityRealm(new HudsonPrivateSecurityRealm(false))

if(!(jenkins.getAuthorizationStrategy() instanceof FullControlOnceLoggedInAuthorizationStrategy))
   jenkins.setAuthorizationStrategy(new FullControlOnceLoggedInAuthorizationStrategy())

// Creating a user in Jenkins using the JENKINS_USER and
// JENKINS_PASS env variables
def user = jenkins.getSecurityRealm().createAccount(env.JENKINS_USER, env.JENKINS_PASS)
// Saving the new user in Jenkins
user.save()
// This is giving our new user JENKINS_USER admin permissions
jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env.JENKINS_USER)
// Saving admin changes
jenkins.save()