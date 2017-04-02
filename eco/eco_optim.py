# -*- coding: utf-8 -*-
"""
Created on Wed Mar  8 20:39:02 2017

@author: luker
"""

def find_residual(x, mat_dhr):
    
    mat_dhr_syn = mat_dhr.copy()
    state = [0., 0., 0.] # home, attic, outside
    state[0] = mat_dhr[0].indoor_temp
    state[1] = mat_dhr[0].indoor_temp
    
    for jT in range(1,len(mat_dhr)):
        dT_seconds = (mat_dhr[jT].day_dec - mat_dhr[jT-1].day_dec)*3600*24
        state[2] = mat_dhr[jT].outdoor_temp
        state = heat_transfer(x, state, dT_seconds)
        mat_dhr_syn[jT] = state[0]
    
    
        
def heat_transfer(x, state, dT_sec):
    
    # Model:
    # Home  <=> Attic
    # Home  <=> Out
    # Attic <=> Out
    
    # for transfer between two spaces, find Q:
    # Q = (kA/d)*deltaTemp
    # Then adjust both temperatures accordingly:
    # => deltaTemp = Q/cM
    # We combine KA/d into one parameter.

    # q is Energy (Heat) transferred per second, in Watts
    # cM is c*M, the (specific heat)*(Mass) of the unit, or
    #  the total heat contained in the unit (joules)
    # c = specific heat (Joules/Kelvin)
    # M = Mass of house or attic
    # K = thermal conductivity in Watts/m/degrees
    # d = thickness of the transfer surface
    # A = Area of transfer surface
    

    # q_ha is Q from House TO Attic
    # q_ha is POSITIVE when the ATTIC is hotter
    # when q_ha is POSITIVE, the HOUSE warms
    
        
    T_house = state[0]
    T_attic = state[1]
    T_out   = state[2]
    
    cM_house = x[0]
    cM_attic = x[1]
    
    KAdinv_ha = x[2]
    KAdinv_ho = x[3]
    KAdinv_ao = x[4]
    
    
    # q is in Watts
    q_AC   = -x[5]
    q_Furn = x[6]
    
    q_ha = KAdinv_ha*(T_attic - T_house)
    # q is Joules/second, aka Watts
    q_ho = KAdinv_ho*(T_out - T_house)
    q_ao = KAdinv_ao*(T_out - T_attic)
    
    T_attic = T_attic - dT_sec*q_ha/cM_attic
    T_house = T_house + dT_sec*q_ha/cM_house
    
    T_attic = T_attic + dT_sec*q_ao/cM_attic
    T_house = T_house + dT_sec*q_ho/cM_house

    T_house = T_house - dT_sec*q_AC/cM_house
    T_house = T_house + dT_sec*q_Furn/cM_house
    
    new_state = (T_house, T_attic, T_out)
    
    return new_state
    
if __name__ == '__main__':
    x = [1000., 1000., 1., 1., 1., 20., 20.,]
    find_residual(x,mat_dhr)