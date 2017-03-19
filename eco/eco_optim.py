# -*- coding: utf-8 -*-
"""
Created on Wed Mar  8 20:39:02 2017

@author: luker
"""

def test_state():
    
    
        
def heat_transfer(x, state, dT_minutes):
    
    # Model:
    # Home  <=> Attic
    # Home  <=> Out
    # Attic <=> Out
    #q = (T1 - T2)/ (((s1/k1 A)) + (s2/k2 A) )
        
    T_house = state[0]
    T_attic = state[1]
    T_out   = state[2]
    
    cM_house = x[0]
    cM_attic = x[1]
    
    KAdinv_ha = x[2]
    KAdinv_ho = x[3]
    KAdinv_ao = x[4]
    
    # q is in Watts
    q_AC   = x[5]
    q_Furn = x[6]
    
    q_ha = KAdinv_ha*(T_attic - T_house)
    # q is Joules/second, aka Watts
    q_ho = KAdinv_ho*(T_out - T_house)
    q_ao = KAdinv_ao*(T_out - T_attic)
    
    T_attic = T_attic - q_ha*cM_attic
    T_house = T_house + q_ha*cM_house
    
    T_attic = T_attic + q_ao*cM_attic
    T_house = T_house + q_ho*cM_house

    T_house = T_house - q_AC*cM_house
    T_house = T_house + q_Furn*cM_house
    
    new_state = [T_house, T_attic, T_out]
    
    return new_state
    
    